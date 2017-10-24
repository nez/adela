FactoryGirl.define do
  factory :distribution do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    download_url { Faker::Internet.url }
    media_type { "application/#{Faker::App.name.downcase}" }
    modified { Faker::Time.backward(365) }
    temporal_init_date { Faker::Date.backward.iso8601 }
    temporal_term_date { Faker::Date.forward.iso8601 }
    spatial { Faker::Address.state }
    issued {  Faker::Time.forward }
    publish_date { Time.current }
    tools { Faker::Lorem.paragraph }
    codelist { Faker::Lorem.paragraph }
    codelist_link { Faker::Internet.url }
    copyright { Faker::Lorem.sentence }
    format { Faker::App.name.downcase }

    factory :distribution_with_dataset do
      dataset
    end
  end
end
