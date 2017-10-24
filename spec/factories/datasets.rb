FactoryGirl.define do
  factory :dataset do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    keyword { Faker::Lorem.words.join(',') }
    modified { Faker::Time.forward }
    contact_position { Faker::Company.profession }
    contact_name { Faker::Name.name }
    mbox { Faker::Internet.safe_email }
    temporal_init_date { Faker::Date.backward.iso8601 }
    temporal_term_date { Faker::Date.forward.iso8601 }
    spatial { "#{Faker::Address.latitude}/#{Faker::Address.longitude}" }
    data_dictionary { Faker::Internet.url }
    accrual_periodicity 'R/P1Y'
    issued { Faker::Time.forward }
    publish_date { Faker::Time.forward }
    comments { Faker::Lorem.paragraph }
    quality { Faker::Internet.url }
    public_access true
    editable true
    catalog

    after(:build) do |dataset|
      dataset.distributions << build(:distribution, dataset: nil)
    end

    factory :dataset_with_sector do
      dataset_sector
    end

    factory :opening_plan_dataset do
      keyword nil
      modified nil
      contact_name nil
      mbox nil
      temporal nil
      spatial nil
      data_dictionary nil
      issued nil
      comments nil
      quality nil
    end
  end
end
