$LOAD_PATH << './lib'

require 'tokenise'
require 'shunt'
require 'runner'

describe Runner do
  def test_eq(text, expected_success, expected_value)
    a = Tokenise.process(text)
    c = Shunt.process(a)

    actual_success, actual_value = Runner.run(c)

    expect(actual_success).to eq(expected_success)
    expect(actual_value).to eq(expected_value)
  end

  def test_raise(text, expected_message)
    a = Tokenise.process(text)
    c = Shunt.process(a)

    expect { Runner.run(c) }.to raise_error(expected_message)
  end

  describe 'various working calculations' do
    it '3 + 2' do
      test_eq('3 + 2', true, 5)
    end

    it '3 - 2' do
      test_eq('3 - 2', true, 1)
    end

    it '3 * 2' do
      test_eq('3 * 2', true, 6)
    end

    it '3 * 2.0' do
      test_eq('3 * 2.0', true, 6)
    end

    it '6 / 3' do
      test_eq('6 / 3', true, 2)
    end

    it '4 ^ 3' do
      test_eq('4 ^ 3', true, 64)
    end
  end

  describe 'boolean operators' do
    it '4 > 3' do
      test_eq('4 > 3', true, true)
    end

    it '4 < 3' do
      test_eq('4 < 3', true, false)
    end

    it 'true && true' do
      test_eq('true && true', true, true)
    end

    it 'true && false' do
      test_eq('true && false', true, false)
    end
  end

  describe 'unitary minus' do
    it '-(12)' do
      test_eq('-(12)', true, -12)
    end

    it '3 - -2' do
      test_eq('3 - -2', true, 5)
    end

    it '3--2' do
      test_eq('3--2', true, 5)
    end
  end

  describe 'raising errors' do
    it '3 * true' do
      test_raise('3 * true', 'Incompatible types true and integer')
    end

    it '4 < "fred"' do
      test_raise('4 < "fred"', 'Incompatible types string and integer')
    end

    it '.level = "error"' do
      test_raise('.level = "error"', 'Operand subtype :query unresolved <OPERAND query .level>')
    end
  end
end
