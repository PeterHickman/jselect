$LOAD_PATH << './lib'

require 'tokenise'
require 'shunt'
require 'runner'
require 'query_resolver'

describe QueryResolver do
  def test_eq(text, data, expected_success, expected_value)
    a = Tokenise.process(text)
    b = Shunt.process(a)
    c = QueryResolver.resolve(data, b)

    actual_success, actual_value = Runner.run(c)

    expect(actual_success).to eq(expected_success), "Success expected=#{expected_success} got=#{actual_success}"
    expect(actual_value).to eq(expected_value), "Value expected=#{expected_value} got=#{actual_value}"
  end

  describe 'with an empty data structure' do
    it 'fails if it references something that is not there' do
      test_eq('.level = "error"', {}, false, nil)
    end
  end

  describe 'with an existing key' do
    it 'matches and returns true' do
      test_eq('.level = "error"', { "level" => "error" }, true, true)
    end

    it 'does not match and returns false' do
      test_eq('.level = "error"', { "level" => "info" }, true, false)
    end
  end

  describe 'boolean && fails' do
    it 'does not match and fails' do
      test_eq('.level = "error" && true', { "level" => "info" }, true, false)
    end

    it 'does match and succeeds' do
      test_eq('.level = "error" && true', { "level" => "error" }, true, true)
    end
  end

  describe 'plain boolean ||' do
    it 'matches nothing' do
      test_eq('.level="error" || .level="debug"', { "level" => 'info' }, true, false)
    end

    it 'matches lhs' do
      test_eq('.level="error" || .level="debug"', { "level" => 'error' }, true, true)
    end

    it 'matches rhs' do
      test_eq('.level="error" || .level="debug"', { "level" => 'debug' }, true, true)
    end
  end

  describe 'boolean || succeeds if something succeeds (magical edge case)' do
    describe 'lhs success true' do
      describe 'rhs success true' do
        it 'success true' do
          test_eq('.level="error" || .other="smith"', { "level" => 'error', "other" => 'smith' }, true, true)
        end
      end

      describe 'rhs success false' do
        it 'success true' do
          test_eq('.level="error" || .other="smith"', { "level" => 'error', "other" => 'notsmith' }, true, true)
        end
      end

      describe 'rhs failed' do
        it 'success true' do
          test_eq('.level="error" || .other="smith"', { "level" => 'error' }, true, true)
        end
      end
    end

    describe 'lhs success false' do
      describe 'rhs success true' do
        it 'success true' do
          test_eq('.level="error" || .other="smith"', { "level" => 'noterror', "other" => 'smith' }, true, true)
        end
      end

      describe 'rhs success false' do
        it 'success false' do
          test_eq('.level="error" || .other="smith"', { "level" => 'noterror', "other" => 'notsmith' }, true, false)
        end
      end

      describe 'rhs failed' do
        it 'success false' do
          test_eq('.level="error" || .other="smith"', { "level" => 'noterror' }, true, false)
        end
      end
    end

    describe 'lhs failed' do
      describe 'rhs success true' do
        it 'success true' do
          test_eq('.level="error" || .other="smith"', { "other" => 'smith' }, true, true)
        end
      end

      describe 'rhs success false' do
        it 'success false' do
          test_eq('.level="error" || .other="smith"', { "other" => 'notsmith' }, true, false)
        end
      end

      describe 'rhs failed' do
        it 'success false' do
          test_eq('.level="error" || .other="smith"', { }, false, nil)
        end
      end
    end
  end
end
