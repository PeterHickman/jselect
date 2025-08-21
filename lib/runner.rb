class Runner
  def self.run(code)
    stack = []

    code.each do |op|
      case op.type
      when :operand
        if op.subtype == :query
          raise "Operand subtype :query unresolved #{op}"
        end

        stack << op
      when :operator
        case op.value
        when '+'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value + f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '-'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value - f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '/'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value / f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '*'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value * f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '^'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value ** f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '>'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value > f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '>='
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value >= f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '<'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value < f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '<='
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value <= f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '='
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value == f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '!='
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && compatible_types(f, s)
            r = s.value != f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '&&'
          f = stack.pop
          s = stack.pop

          if no_problem_so_far(f, s) && bool_types(f, s)
            r = s.value && f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when '||'
          f = stack.pop
          s = stack.pop

          # There is a special case here where one operand fails
          # but the other succeeds and evaluates to true then this
          # can return true and if everything has failed return false
          if bool_types(f, s, [:true, :false, :error])
            v = nil
            x = false

            if f.success
              x = true

              if s.success
                v = f.value || s.value
              else
                v = f.value
              end
            elsif s.success
              x = true
              v = s.value
            end

            stack << ExtendedToken.new(type: :operand, subtype: sym_of(v), value: v, success: x)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        when 'neg' # The only unary operator (so far)
          f = stack.pop

          if f.success && number_type(f)
            r = -1 * f.value
            stack << ExtendedToken.new(type: :operand, subtype: sym_of(r), value: r, success: true)
          else
            stack << ExtendedToken.new(type: :operand, subtype: :error, value: nil, success: false)
          end
        else
          raise "Unknown operator #{op}"
        end
      else
        raise "Unknown type #{op}"
      end
    end

    raise "Stack should have one element not #{stack.size}" unless stack.size == 1

    [stack[0].success, stack[0].value]
  end

  def self.sym_of(value)
    if value.kind_of?(TrueClass)
      :true
    elsif value.kind_of?(FalseClass)
      :false
    elsif value.kind_of?(Integer)
      :integer
    elsif value.kind_of?(Float)
      :float
    elsif value.kind_of?(NilClass)
      :null
    else
      raise "Unknown sym_of #{value.class}"
    end
  end

  def self.bool_types(a, b, list = [:true, :false])
    list.include?(a.subtype) && list.include?(b.subtype)
  end

  def self.number_type(a)
    [:integer, :float].include?(a.subtype)
  end

  def self.compatible_types(a, b)
    return true if a.subtype == b.subtype

    return true if number_type(a) && number_type(b)

    return true if bool_types(a, b)

    raise "Incompatible types #{a.subtype} and #{b.subtype}"

    false
  end

  def self.no_problem_so_far(a, b)
    a.success && b.success
  end

  def self.any_success(a, b)
    a.success || b.success
  end
end
