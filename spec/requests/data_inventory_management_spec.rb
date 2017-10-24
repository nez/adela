require 'spec_helper'

feature 'data inventory management' do
  let(:organization) { create(:organization) }

  scenario 'can consume published catalog data' do
    catalog = create(:catalog, organization: organization)
    dataset = create(:dataset, catalog: catalog)
    create(:distribution, dataset: dataset)

    get "/api/v1/organizations/#{organization.slug}/inventory.json"
    json_response = JSON.parse(response.body)
    expect(json_response['title']).to eql("Plan de Apertura Institucional de #{organization.title}")
    expect(json_response['dataset']).not_to be_empty
  end

  scenario 'catalog will have correct DCAT key names' do
    catalog = create(:catalog, organization: organization)
    dataset = create(:dataset, catalog: catalog)
    create(:distribution, dataset: dataset)

    dcat_keys = %w(title dataset)
    dcat_dataset_keys = %w(
      id title description issued modified identifier keyword language public
      contactPoint temporal spatial accrualPeriodicity landingPage publisher
      publishDate distribution openessRating govType theme comments quality
      dataDictionary createdAt
    )
    dcat_distribution_keys = %w(
      id title description issued modified license downloadURL mediaType format
      temporal spatial publishDate tools createdAt
    )

    get "/api/v1/organizations/#{organization.slug}/inventory.json"
    json_response = JSON.parse(response.body)

    expect(json_response.keys).to eq(dcat_keys)
    expect(json_response['dataset'].last.keys.sort).to eq(dcat_dataset_keys.sort)
    expect(json_response['dataset'].last['distribution'].last.keys.sort).to eq(dcat_distribution_keys.sort)
  end
end
