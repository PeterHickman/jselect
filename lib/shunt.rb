class ExtendedToken
  attr_reader :type, :precedence, :left_associative, :value, :success, :subtype
  attr_writer :success, :value, :subtype

  def initialize(token)
    @type = nil
    @subtype = nil
    @value = nil
    @success = true
    @precedence = 99999
    @left_associative = false

    if token.kind_of?(Hash)
      fill_in_from_hash(token)
    else
      fill_in_from_token(token)
    end
  end

  def to_s
    if @subtype == :error
      "<ERROR #{@value}>"
    elsif @type == :open_paren
      '<OPEN_PAREN>'
    elsif @type == :close_paren
      '<CLOSE_PAREN>'
    elsif @type == :operator
      "<OPERATOR #{@value} #{@precedence} #{@left_associative}>"
    elsif @type == :operand
      "<OPERAND #{@subtype} #{@value}>"
    end
  end

  private

  def fill_in_from_token(token)
    case token.type
    when :comparison, :boolean, :operator
      @type = :operator
      @value = token.value
      @precedence = operator_precedence(token.value)
      @left_associative = operator_associativity(token.value) == 'left'
    when :open_paren, :close_paren
      @type = token.type
      @precedence = operator_precedence(token.value)
    when :float, :integer, :true, :false, :null, :string, :query
      @type = :operand
      @subtype = token.type
      @value = token.value
    when :error
      @type = :operand
      @subtype = token.type
      @value = token.value
      @success = false
    else
      raise "Unknown token type [#{token.type}] from Tokenise"
    end
  end

  def fill_in_from_hash(token)
    token.each do |k, v|
      case k
      when :type
        @type = v
      when :subtype
        @subtype = v
      when :value
        @value = v
      when :success
        @success = v
      else
        raise "Option #{k} => #{v} unknown key"
      end
    end

    if [:operator, :open_paren, :close_paren].include?(@type)
      @precedence = operator_precedence(@value)
      @left_associative = operator_associativity(@value) == 'left'
    end
  end

  def operator_precedence(token_value)
    case token_value
    when '(', ')'
      0
    when 'neg' # Unary minus
      14
    when '^' # The exponential operator
      13
    when '*', '/'
      12
    when '+', '-'
      11
    when '<', '<=', '>', '>='
      9
    when '=', '!='
      8
    when '&&'
      4
    when '||'
      3
    else
      raise "Precedence unknown for [#{token_value}]"
    end
  end

  def operator_associativity(token_value)
    case token_value
    when '(', ')'
      nil
    when '^'
      'right'
    when '*', '/'
      'left'
    when '+', '-'
      'left'
    when '<', '<=', '>', '>='
      'left'
    when '=', '!='
      'left'
    when '&&'
      'left'
    when '||'
      'left'
    when 'neg' # Unary minus
      'right'
    else
      raise "Associativity unknown for [#{token_value}]"
    end
  end
end

class Shunt
  def self.process(tokens)
    stack = []
    queue = []

    input = tokens.map { |token| ExtendedToken.new(token) }

    while input.any?
      token = input.shift

      if token.type == :operand
        queue << token
      elsif token.type == :operator
        while stack.any? && token.precedence <= stack.last.precedence && token.left_associative
          queue << stack.pop
        end

        stack << token
      elsif token.type == :open_paren
        stack << token
      elsif token.type == :close_paren
        while stack.any? && stack.last.type != :open_paren
          queue << stack.pop
        end

        stack.pop
      else
        raise "Do not know what to do with [#{token}]. Not an operator, operand, '(' or ')'"
      end
    end

    while stack.any?
      queue << stack.pop
    end

    queue
  end
end
