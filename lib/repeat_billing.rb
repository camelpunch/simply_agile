module RepeatBilling
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def repeat_billing
      File.open(log_file_name, "a") do |log_file|
        billable.each do |billable_instance|
          log_file.print(
            Time.now.to_s +
              " Billing #{billable_instance.class.name.downcase} " +
              "'#{billable_instance.name}'..."
          )
          begin
            billable_instance.take_payment
            log_file.puts("SUCCESS")
          rescue StandardError => e
            log_file.puts("FAILURE #{e.class}")
          end
        end
      end
    end

    def log_file_name
      File.expand_path(File.join(RAILS_ROOT, 'log', 'repeat_billing.log'))
    end
  end
end