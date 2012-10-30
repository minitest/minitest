require 'minitest/autorun'

describe 'at_exit', 'when dealing with exceptions' do
  ruby = 'ruby -I lib -r minitest/autorun'

  it 'runs tests if no exception was raised' do
    `#{ruby} -e nil`.wont_be_empty
  end

  it 'runs tests if SystemExit was raised' do
    `#{ruby} -e exit`.wont_be_empty
    `#{ruby} -e 'at_exit { exit }'`.wont_be_empty
    `#{ruby} -e 'at_exit { raise SystemExit }'`.wont_be_empty
  end

  it 'does not run tests if an exception other than SystemExit was raised' do
    `#{ruby} -e 'at_exit { raise }' 2>/dev/null`.must_be_empty
    `#{ruby} -e 'at_exit { raise Exception }' 2>/dev/null`.must_be_empty
  end
end
