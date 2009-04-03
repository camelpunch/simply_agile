class BillingAddress < ActiveRecord::Base
  validates_presence_of(:name, 
                        :address_line_1, 
                        :town, 
                        :postcode, 
                        :country,
                        :telephone_number)
end
