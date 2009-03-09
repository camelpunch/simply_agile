class Organisations < ObjectMother
  truncate_organisation

  define_organisation(:jandaweb, :name => 'Jandaweb')
end
