module ModelHelpers
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def it_should_be_accessible(name, sample_data, options = {})
      describe "when initialized with .new(:#{name} => '#{sample_data}')" do

        let(:accessor_value) do
          subject.class.send(:new, { name => sample_data }).send(name)
        end

        if options[:accessible]
          if options[:accessible] == true
            it "should == '#{sample_data}'" do
              accessor_value.should == sample_data
            end
          else
            it "##{options[:accessible].keys.first} should be #{options[:accessible].values.first}" do
              subject.send(options[:accessible].keys.first).should == options[:accessible].values.first
            end
          end
        else
          it "should be nil" do
            accessor_value.should be_nil
          end
        end
      end
    end

    def it_should_delegate(name, options = {})
      sample_data = "sample_#{name.to_s}"
      delegation_object, delegation_method = options[:to].split("#")

      describe "##{name} = '#{sample_data}'" do
        it "should set the #{delegation_object}'s #{delegation_method}" do
          subject.send("#{name}=", sample_data)
          subject.send(delegation_object).send(delegation_method).should == sample_data
        end
      end

      describe "##{name}" do
        it "should return the #{delegation_method} from the #{delegation_object}" do
          subject.send(delegation_object).send("#{delegation_method}=", sample_data)
          subject.send(name).should == sample_data
        end

        it_should_be_accessible(name, sample_data, options)
      end
    end

    def it_should_have_accessor(name, options = {})
      if name.is_a?(Hash)
        key = name.keys.first
        sample_data = name[key]
        name = key
      else
        sample_data = "sample_#{name.to_s}"
      end

      it "should respond to ##{name}=" do
        subject.should respond_to("#{name}=")
      end

      describe "##{name}" do
        context "where the #{name} is set to '#{sample_data}'" do
          before { subject.send("#{name}=", sample_data) }

          it "should == '#{sample_data}'" do
            subject.send(name).should == sample_data
          end
        end

        it_should_be_accessible(name, sample_data, options) if options[:accessible].present?
      end
    end
  end
end

