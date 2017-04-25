describe HP12C do

  RSpec::Matchers.define :be_ok_if do |expected|
    match do |actual|
      subject.eval(actual)
      @actual = expected.keys.inject({}){|hash, key| hash[key] = subject.public_send(key) ; hash }
      values_match? @actual, expected
    end

    description do
      "to compute #{expected}"
    end

    diffable
  end

  subject { described_class.new }

  context 'simple x, y and z moves' do
    it { expect(%||).to be_ok_if(x: 0,  y: 0, z: 0) }
    it { expect(%|1\n|).to be_ok_if(x: 1, y: 0, z: 0) }
    it { expect(%|1\n\n|).to be_ok_if(x: 0, y: 1, z: 0) }
    it { expect(%|1\n\n\n|).to be_ok_if(x: 0, y: 0, z: 1) }
    it { expect(%|1\n2\n+\n|).to be_ok_if(x: 3, y: 2, z: 1) }
    it { expect(%|1\n2\n+\n+\n|).to be_ok_if(x: 5, y: 3, z: 2) }
    it { expect(%|1\n2\n+\n5\n+|).to be_ok_if(x: 8, y: 5, z: 3) }
  end

  context 'operators + - / *' do
    it { expect(%|10\n2\n+\n|).to be_ok_if(x: 12) }
    it { expect(%|10\n2\n-\n|).to be_ok_if(x: 8) }
    it { expect(%|10\n2\n/\n|).to be_ok_if(x: 5) }
    it { expect(%|10\n2\n*\n|).to be_ok_if(x: 20) }
  end

  context 'memory storage' do
    it { expect(%|10\nsto 1\n|).to be_ok_if(mem: {'1' => 10.0}) }
    it { expect(%|10\n2\n+\nsto 2\n|).to be_ok_if(mem: {'2' => 12.0}) }
  end

  context 'memory recover' do
    it { expect(%|rcl 1\n|).to be_ok_if(x: nil) }
    it { expect(%|10\nsto 1\nrcl 1\n|).to be_ok_if(x: 10) }
  end

  context 'complete example' do
    let(:input) { <<~CODE }
      123
      sto 1
      456
      sto 2
      789
      sto 3

      rcl 3
      rcl 2
      +
      rcl 1
      +
      sto 4
    CODE

    specify do
      expect(input).to be_ok_if(
        x: 1368.0,
        y: 123.0,
        z: 1245.0,
        mem: {
          "1" => 123.0,
          "2" => 456.0,
          "3" => 789.0,
          "4" => 1368.0
        }
      )
    end
  end
end
