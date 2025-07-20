$LOAD_PATH << './lib'

require 'tokenise'

describe Tokenise do
  def compare_element(element, type, text, value)
    expect(element.type).to eq(type)
    expect(element.string).to eq(text)
    expect(element.value).to eq(value)
  end

  def compare_all_raw(text, list)
    l = Tokenise.process(text, true)

    expect(l.size).to eq(list.size)
    list.each_with_index do |x, i|
      compare_element(l[i], *x)
    end
  end

  def compare_all_cooked(text, list)
    l = Tokenise.process(text, false)

    expect(l.size).to eq(list.size)
    list.each_with_index do |x, i|
      compare_element(l[i], *x)
    end
  end

  describe 'Integers' do
    it 'parses a positve number' do
      compare_all_raw('12', [[:integer, '12', 12]])
    end
  end

  describe 'Floats' do
    it 'parses a positve number' do
      compare_all_raw('1.23', [[:float, '1.23', 1.23]])
    end
  end

  describe 'Nulls' do
    it 'returns the native type' do
      compare_all_raw('null', [[:null, 'null', nil]])
    end
  end

  describe 'True' do
    it 'returns the native type' do
      compare_all_raw('true', [[:true, 'true', true]])
    end
  end

  describe 'False' do
    it 'returns the native type' do
      compare_all_raw('false', [[:false, 'false', false]])
    end
  end

  describe 'Strings' do
    it 'with single quotes' do
      compare_all_raw("'fred'", [[:string, "'fred'", 'fred']])
    end

    it 'with double quotes' do
      compare_all_raw('"fred"', [[:string, '"fred"', 'fred']])
    end
  end

  describe 'Open parens' do
    it 'returns the character' do
      compare_all_raw('(', [[:open_paren, '(', '(']])
    end
  end

  describe 'Close parens' do
    it 'returns the character' do
      compare_all_raw(')', [[:close_paren, ')', ')']])
    end
  end

  describe 'Queries' do
    it 'matches a single level' do
      compare_all_raw('.level', [[:query, '.level', '.level']])
    end

    it 'matches multiple levels' do
      compare_all_raw('.level.seq.outing', [[:query, '.level.seq.outing', '.level.seq.outing']])
    end
  end

  describe 'Booleans' do
    it 'returns the &&' do
      compare_all_raw('&&', [[:boolean, '&&', '&&']])
    end

    it 'returns the ||' do
      compare_all_raw('||', [[:boolean, '||', '||']])
    end
  end

  describe 'Comparisons' do
    it 'returns the =' do
      compare_all_raw('=', [[:comparison, '=', '=']])
    end

    it 'returns the !=' do
      compare_all_raw('!=', [[:comparison, '!=', '!=']])
    end

    it 'returns the >=' do
      compare_all_raw('>=', [[:comparison, '>=', '>=']])
    end

    it 'returns the >' do
      compare_all_raw('>', [[:comparison, '>', '>']])
    end

    it 'returns the <=' do
      compare_all_raw('<=', [[:comparison, '<=', '<=']])
    end

    it 'returns the <' do
      compare_all_raw('<', [[:comparison, '<', '<']])
    end
  end

  describe 'Operators' do
    it 'returns the -' do
      compare_all_raw('-', [[:operator, '-', '-']])
    end

    it 'returns the +' do
      compare_all_raw('+', [[:operator, '+', '+']])
    end

    it 'returns the *' do
      compare_all_raw('*', [[:operator, '*', '*']])
    end

    it 'returns the /' do
      compare_all_raw('/', [[:operator, '/', '/']])
    end

    it 'returns the ^' do
      compare_all_raw('^', [[:operator, '^', '^']])
    end
  end

  describe 'Unary minus' do
    describe 'in raw mode' do
      it '-12' do
        compare_all_raw('-12', [[:operator, '-', '-'], [:integer, '12', 12]])
      end

      it '1 - 2' do
        compare_all_raw('1 - 2', [[:integer, '1', 1], [:operator, '-', '-'], [:integer, '2', 2]])
      end

      it '1 - -2' do
        compare_all_raw('1 - -2', [[:integer, '1', 1], [:operator, '-', '-'], [:operator, '-', '-'], [:integer, '2', 2]])
      end

      it '(1) - 2' do
        compare_all_raw('(1) - 2', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:integer, '2', 2]])
      end

      it '(1) - -2' do
        compare_all_raw('(1) - -2', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:operator, '-', '-'], [:integer, '2', 2]])
      end

      it '-(12)' do
        compare_all_raw('-(12)', [[:operator, '-', '-'], [:open_paren, '(', '('], [:integer, '12', 12], [:close_paren, ')', ')']])
      end

      it '(1) - (2)' do
        compare_all_raw('(1) - (2)', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:open_paren, '(', '('], [:integer, '2', 2], [:close_paren, ')', ')']])
      end

      it '(1) - -(2)' do
        compare_all_raw('(1) - -(2)', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:operator, '-', '-'], [:open_paren, '(', '('], [:integer, '2', 2], [:close_paren, ')', ')']])
      end
    end

    describe 'in cooked mode' do
      it '-12' do
        compare_all_cooked('-12', [[:integer, '-12', -12]])
      end

      it '1 - 2' do
        compare_all_cooked('1 - 2', [[:integer, '1', 1], [:operator, '-', '-'], [:integer, '2', 2]])
      end

      it '1 - -2' do
        compare_all_cooked('1 - -2', [[:integer, '1', 1], [:operator, '-', '-'], [:integer, '-2', -2]])
      end

      it '(1) - 2' do
        compare_all_cooked('(1) - 2', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:integer, '2', 2]])
      end

      it '(1) - -2' do
        compare_all_cooked('(1) - -2', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:integer, '-2', -2]])
      end

      it '-(12)' do
        compare_all_cooked('-(12)', [[:operator, 'neg', 'neg'], [:open_paren, '(', '('], [:integer, '12', 12], [:close_paren, ')', ')']])
      end

      it '(1) - (2)' do
        compare_all_cooked('(1) - (2)', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:open_paren, '(', '('], [:integer, '2', 2], [:close_paren, ')', ')']])
      end

      it '(1) - -(2)' do
        compare_all_cooked('(1) - -(2)', [[:open_paren, '(', '('], [:integer, '1', 1], [:close_paren, ')', ')'], [:operator, '-', '-'], [:operator, 'neg', 'neg'], [:open_paren, '(', '('], [:integer, '2', 2], [:close_paren, ')', ')']])
      end
    end
  end
end
