class Token
  attr_reader :type, :string, :value
  attr_writer :string, :value

  def initialize(type, string)
    @type = type
    @string = string
    @value = value_from_string(type, string)
  end

  def inspect
    "{TOKEN #{@type} [#{@string}]}"
  end

  private

  def value_from_string(type, string)
    case type
    when :integer
      string.to_i
    when :float
      string.to_f
    when :string
      string[1..-2]
    when :true
      true
    when :false
      false
    when :null
      nil
    else
      string
    end
  end
end

class Tokenise
  COMPARISONS = %w[= != >= > <= <]

  OPERATORS = %w[- + * / ^]

  BOOLEAN = %w[&& ||]

  ORDERED = [
    [:whitespace, :ws],
    [:comparison, :comp],
    [:boolean, :bool],
    [:operator, :ops],
    [:float, :float],
    [:integer, :int],
    [:true, :true],
    [:false, :false],
    [:null, :null],
    [:string, :string_double],
    [:string, :string_single],
    [:open_paren, :open_paren],
    [:close_paren, :close_paren],
    [:query, :query],
  ]

  def self.process(text, raw = false)
    l = []

    loop do
      not_matched = true

      ORDERED.each do |(label, func)|
        r = send(func, text)
        next if r.nil?

        l << Token.new(label, r.dup) unless label == :whitespace
        text = text[r.size..]
        not_matched = false
        break
      end

      if not_matched
        l << Token.new(:error, text)
        break
      end

      break if text == ''
    end

    l = unary_minus(l) unless raw

    l
  end

  private

  def self.unary_minus(list)
    l = []

    while list.any?
      token = list.shift

      if token.type == :operator && token.value == '-'
        if l.empty?
          if list.first.type == :integer || list.first.type == :float
            list[0] = Token.new(list.first.type, (-1 * list.first.value).to_s)
          elsif list.first.type == :open_paren
            l << Token.new(:operator, 'neg')
          else
            raise "Exception unary minus 1 #{l.last} #{token} #{list.first}"
          end
        else
          if l.last.type == :integer || l.last.type == :float
            l << token
          elsif l.last.type == :operator && (list.first.type == :integer || list.first.type == :float)
            list[0] = Token.new(list.first.type, (-1 * list.first.value).to_s)
          elsif l.last.type == :close_paren
            l << token
          elsif l.last.type == :operator && list.first.type == :open_paren
            l << Token.new(:operator, 'neg')
          else
            raise "Exception unary minus 2 #{l.last} #{token} #{list.first}"
          end
        end
      else
        l << token
      end
    end

    l
  end

  def self.ws(text)
    if text =~ /^(\s+)/
      $1
    else
      nil
    end
  end

  def self.ops(text)
    OPERATORS.each do |o|
      return o if text.start_with?(o)
    end

    nil
  end

  def self.comp(text)
    COMPARISONS.each do |c|
      return c if text.start_with?(c)
    end

    nil
  end

  def self.bool(text)
    BOOLEAN.each do |b|
      return b if text.start_with?(b)
    end

    nil
  end

  def self.query(text)
    if text =~ /^([\.[a-zA-Z0-9_]+]+)/
      $1
    else
      nil
    end
  end

  def self.string_single(text)
    return nil unless text.start_with?("'")

    # We know the char at 0 is a '
    (1...text.size).each do |i|
      next unless text[i] == "'"
      return text[0..i]
    end

    nil
  end

  def self.string_double(text)
    return nil unless text.start_with?('"')

    # We know the char at 0 is a "
    (1...text.size).each do |i|
      next unless text[i] == '"'
      return text[0..i]
    end

    nil
  end

  def self.open_paren(text)
    if text.start_with?('(')
      '('
    else
      nil
    end
  end

  def self.close_paren(text)
    if text.start_with?(')')
      ')'
    else
      nil
    end
  end

  def self.int(text)
    if text =~ /^(\d+)/
      $1
    else
      nil
    end
  end

  def self.float(text)
    if text =~ /^(\d+\.\d+)/
      $1
    else
      nil
    end
  end

  def self.true(text)
    return 'true' if text.downcase.start_with?('true')

    nil
  end

  def self.false(text)
    return 'false' if text.downcase.start_with?('false')

    nil
  end

  def self.null(text)
    return 'null' if text.downcase.start_with?('null')

    nil
  end
end
