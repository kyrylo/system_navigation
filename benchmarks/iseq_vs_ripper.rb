# coding: utf-8
require 'benchmark'
require 'ripper'

require_relative '../lib/system_navigation'

=begin
Rehearsal ------------------------------------------                                                                                                                                  │
iseq    61.100000   0.170000  61.270000 ( 61.583993)                                                                                                                                  │
ripper  42.610000   0.000000  42.610000 ( 42.758335)                                                                                                                                  │
------------------------------- total: 103.880000sec                                                                                                                                  │
                                                                                                                                                                                      │
             user     system      total        real                                                                                                                                   │
iseq    61.270000   0.100000  61.370000 ( 61.751335)                                                                                                                                  │
ripper  43.940000   0.010000  43.950000 ( 44.094953)                                                                                                                                  │
ruby benchmarks/iseq_vs_ripper.rb  209.00s user 0.29s system 99% cpu 3:30.29 total
=end

prybm = <<'CLASS'
class PryBM
  attr_accessor :binding_stack
  attr_accessor :custom_completions
  attr_accessor :eval_string
  attr_accessor :backtrace
  attr_accessor :suppress_output
  attr_accessor :last_result
  attr_accessor :last_file
  attr_accessor :last_dir

  attr_reader :last_exception
  attr_reader :command_state
  attr_reader :exit_value
  attr_reader :input_array
  attr_reader :output_array
  attr_reader :config

  def initialize(options={})
    @binding_stack = []
    @indent        = Pry::Indent.new
    @command_state = {}
    @eval_string   = ""
    @backtrace     = options.delete(:backtrace) || caller
    target = options.delete(:target)
    @config = Pry::Config.new
    config.merge!(options)
    push_prompt(config.prompt)
    @input_array  = Pry::HistoryArray.new config.memory_size
    @output_array = Pry::HistoryArray.new config.memory_size
    @custom_completions = config.command_completions
    set_last_result nil
    @input_array << nil
    push_initial_binding(target)
    exec_hook(:when_started, target, options, self)
  end

  def prompt
    prompt_stack.last
  end

  def prompt=(new_prompt)
    if prompt_stack.empty?
      push_prompt new_prompt
    else
      prompt_stack[-1] = new_prompt
    end
  end

  def push_initial_binding(target=nil)
    push_binding(target || Pry.toplevel_binding)
  end


  def current_binding
    binding_stack.last
  end
  alias current_context current_binding # support previous API


  def push_binding(object)
    @stopped = false
    binding_stack << Pry.binding_for(object)
  end


  def complete(str)
    return EMPTY_COMPLETIONS unless config.completer
    Pry.critical_section do
      completer = config.completer.new(config.input, self)
      completer.call str, target: current_binding, custom_completions: custom_completions.call.push(*sticky_locals.keys)
    end
  end


  def inject_local(name, value, b)
    value = Proc === value ? value.call : value
    if b.respond_to?(:local_variable_set)
      b.local_variable_set name, value
    else # < 2.1
      begin
        Pry.current[:pry_local] = value
        b.eval "#{name} = ::Pry.current[:pry_local]"
      ensure
        Pry.current[:pry_local] = nil
      end
    end
  end

  def memory_size
    @output_array.max_size
  end

  def memory_size=(size)
    @input_array  = Pry::HistoryArray.new(size)
    @output_array = Pry::HistoryArray.new(size)
  end

  def inject_sticky_locals!
    sticky_locals.each_pair do |name, value|
      inject_local(name, value, current_binding)
    end
  end

  def add_sticky_local(name, &block)
    config.extra_sticky_locals[name] = block
  end

  def sticky_locals
    { _in_: input_array,
      _out_: output_array,
      _pry_: self,
      _ex_: last_exception && last_exception.wrapped_exception,
      _file_: last_file,
      _dir_: last_dir,
      _: proc { last_result },
      __: proc { output_array[-2] }
    }.merge(config.extra_sticky_locals)
  end


  def reset_eval_string
    @eval_string = ""
  end

  def eval(line, options={})
    return false if @stopped

    exit_value = nil
    exception = catch(:raise_up) do
      exit_value = catch(:breakout) do
        handle_line(line, options)
        return !@stopped
      end
      exception = false
    end

    @stopped = true
    @exit_value = exit_value

    raise exception if exception
    return false
  end

  def handle_line(line, options)
    if line.nil?
      config.control_d_handler.call(@eval_string, self)
      return
    end

    ensure_correct_encoding!(line)
    Pry.history << line unless options[:generated]

    @suppress_output = false
    inject_sticky_locals!
    begin
      if !process_command_safely(line)
        @eval_string << "#{line.chomp}\n" if !line.empty? || !@eval_string.empty?
      end
    rescue RescuableException => e
      self.last_exception = e
      result = e

      Pry.critical_section do
        show_result(result)
      end
      return
    end

    exec_hook :after_read, eval_string, self

    begin
      complete_expr = Pry::Code.complete_expression?(@eval_string)
    rescue SyntaxError => e
      output.puts "SyntaxError: #{e.message.sub(/.*syntax error, */m, '')}"
      reset_eval_string
    end

    if complete_expr
      if @eval_string =~ /;\Z/ || @eval_string.empty? || @eval_string =~ /\A *#.*\n\z/
        @suppress_output = true
      end

      jruby_exceptions = []
      if Pry::Helpers::BaseHelpers.jruby?
        jruby_exceptions << Java::JavaLang::Exception
      end

      begin
        eval_string = @eval_string
        reset_eval_string

        result = evaluate_ruby(eval_string)
      rescue RescuableException, *jruby_exceptions => e
        if Pry::Helpers::BaseHelpers.jruby? && e.class.respond_to?('__persistent__')
          e.class.__persistent__ = true
        end
        self.last_exception = e
        result = e
      end

      Pry.critical_section do
        show_result(result)
      end
    end

    throw(:breakout) if current_binding.nil?
  end
  private :handle_line

  def repl(target = nil)
    Pry::REPL.new(self, :target => target).start
  end

  def evaluate_ruby(code)
    inject_sticky_locals!
    exec_hook :before_eval, code, self

    result = current_binding.eval(code, Pry.eval_path, Pry.current_line)
    set_last_result(result, code)
  ensure
    update_input_history(code)
    exec_hook :after_eval, result, self
  end

  def show_result(result)
    if last_result_is_exception?
      exception_handler.call(output, result, self)
    elsif should_print?
      print.call(output, result, self)
    else
      # nothin'
    end
  rescue RescuableException => e
    begin
      output.puts "(pry) output error: #{e.inspect}"
    rescue RescuableException => e
      if last_result_is_exception?
        output.puts "(pry) output error: failed to show exception"
      else
        output.puts "(pry) output error: failed to show result"
      end
    end
  ensure
    output.flush if output.respond_to?(:flush)
  end

  def ensure_correct_encoding!(val)
    if @eval_string.empty? &&
        val.respond_to?(:encoding) &&
        val.encoding != @eval_string.encoding
      @eval_string.force_encoding(val.encoding)
    end
  end
  private :ensure_correct_encoding!

  def process_command(val)
    val = val.lstrip if /^\s\S/ !~ val
    val = val.chomp
    result = commands.process_line(val,
      :target => current_binding,
      :output => output,
      :eval_string => @eval_string,
      :pry_instance => self,
      :hooks => hooks
    )

    Pry.current[:pry_cmd_result] = result

    if result.command?
      if !result.void_command?
        @eval_string.replace "::Pry.current[:pry_cmd_result].retval\n"
      end
      true
    else
      false
    end
  end

  def process_command_safely(val)
    process_command(val)
  rescue CommandError, Slop::InvalidOptionError, MethodSource::SourceNotFoundError => e
    Pry.last_internal_error = e
    output.puts "Error: #{e.message}"
    true
  end

  def run_command(val)
    commands.process_line(val,
      :eval_string => @eval_string,
      :target => current_binding,
      :pry_instance => self,
      :output => output
    )
    Pry::Command::VOID_VALUE
  end

  def exec_hook(name, *args, &block)
    e_before = hooks.errors.size
    hooks.exec_hook(name, *args, &block).tap do
      hooks.errors[e_before..-1].each do |e|
        output.puts "#{name} hook failed: #{e.class}: #{e.message}"
        output.puts "#{e.backtrace.first}"
        output.puts "(see _pry_.hooks.errors to debug)"
      end
    end
  end

  def set_last_result(result, code="")
    @last_result_is_exception = false
    @output_array << result

    self.last_result = result unless code =~ /\A\s*\z/
  end

  def last_exception=(e)
    last_exception = Pry::LastException.new(e)
    @last_result_is_exception = true
    @output_array << last_exception
    @last_exception = last_exception
  end

  def update_input_history(code)
    @input_array << code
    if code
      Pry.line_buffer.push(*code.each_line)
      Pry.current_line += code.lines.count
    end
  end

  def last_result_is_exception?
    @last_result_is_exception
  end

  def should_print?
    !@suppress_output
  end

  def select_prompt
    object = current_binding.eval('self')

    open_token = @indent.open_delimiters.any? ? @indent.open_delimiters.last :
      @indent.stack.last

    c = Pry::Config.from_hash({
                       :object         => object,
                       :nesting_level  => binding_stack.size - 1,
                       :open_token     => open_token,
                       :session_line   => Pry.history.session_line_count + 1,
                       :history_line   => Pry.history.history_line_count + 1,
                       :expr_number    => input_array.count,
                       :_pry_          => self,
                       :binding_stack  => binding_stack,
                       :input_array    => input_array,
                       :eval_string    => @eval_string,
                       :cont           => !@eval_string.empty?})

    Pry.critical_section do
      if eval_string.empty?
        generate_prompt(Array(prompt).first, c)

      else
        generate_prompt(Array(prompt).last, c)
      end
    end
  end

  def generate_prompt(prompt_proc, conf)
    if prompt_proc.arity == 1
      prompt_proc.call(conf)
    else
      prompt_proc.call(conf.object, conf.nesting_level, conf._pry_)
    end
  end
  private :generate_prompt

  def prompt_stack
    @prompt_stack ||= Array.new
  end
  private :prompt_stack

  def push_prompt(new_prompt)
    prompt_stack.push new_prompt
  end

  def pop_prompt
    prompt_stack.size > 1 ? prompt_stack.pop : prompt
  end

  def pager
    Pry::Pager.new(self)
  end

  def output
    Pry::Output.new(self)
  end

  def raise_up_common(force, *args)
    exception = if args == []
                  last_exception || RuntimeError.new
                elsif args.length == 1 && args.first.is_a?(String)
                  RuntimeError.new(args.first)
                elsif args.length > 3
                  raise ArgumentError, "wrong number of arguments"
                elsif !args.first.respond_to?(:exception)
                  raise TypeError, "exception class/object expected"
                elsif args.length === 1
                  args.first.exception
                else
                  args.first.exception(args[1])
                end

    raise TypeError, "exception object expected" unless exception.is_a? Exception

    exception.set_backtrace(args.length === 3 ? args[2] : caller(1))

    if force || binding_stack.one?
      binding_stack.clear
      throw :raise_up, exception
    else
      binding_stack.pop
      raise exception
    end
  end
  def raise_up(*args); raise_up_common(false, *args); end
  def raise_up!(*args); raise_up_common(true, *args); end

  def quiet?
    config.quiet
  end
end
CLASS

TIMES = 10_000

Benchmark.bmbm do |bm|
  bm.report('iseq') do
    TIMES.times do
      RubyVM::InstructionSequence.compile(prybm).disasm
    end
  end

  bm.report('ripper') do
    TIMES.times do
      Ripper.sexp(prybm)
    end
  end
end
