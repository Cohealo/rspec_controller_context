RSpec.describe RspecControllerContext::OptionProvider do
  describe "valid_method_name?" do
    {
      "a_good_name" => true,
      "Okay" => true,
      "fine?" => true,
      "fine=" => true,
      "find!" => true,
      "ab?cd" => false,
      "okay123" => true,
      "123okay" => false,
      "_fine" => true,
      "$" => false,
    }.each do |name, is_valid|
      it "should return #{is_valid} for #{name.inspect}" do
        expect(described_class.send(:valid_method_name?, name)).
          to eq is_valid
      end
    end
  end
end
