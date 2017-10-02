require 'spec_helper'

feature 'Catalog dataset metadata' do
  before do
    @user = FactoryGirl.create(:user)
    given_logged_in_as(@user)
  end

  scenario 'fills the dataset metadata' do
    catalog = create(:catalog, organization: @user.organization)
    dataset = create(:opening_plan_dataset, catalog: catalog)
    visit edit_dataset_path(dataset)

    dataset_attributes = attributes_for(:dataset)
    fill_catalog_dataset_metadata(dataset_attributes)
    click_on 'Guardar'

    visit edit_dataset_path(dataset)

    expect(page).to have_field('dataset_contact_name', with: dataset_attributes[:contact_name])
    expect(page).to have_field('dataset_mbox', with: dataset_attributes[:mbox])
    expect(page).to have_field('dataset_spatial', with: dataset_attributes[:spatial])
    expect(page).to have_field('dataset_spatial', with: dataset_attributes[:spatial])
    expect(page).to have_field('dataset_data_dictionary', with: dataset_attributes[:data_dictionary])
    expect(page).to have_field('dataset_quality', with: dataset_attributes[:quality])
    expect(page).to have_field('dataset_keyword', with: dataset_attributes[:keyword])
    expect(page).to have_field('dataset_comments', with: dataset_attributes[:comments])
  end

  def fill_catalog_dataset_metadata(dataset_attributes)
    fill_in('dataset_contact_name', with: dataset_attributes[:contact_name])
    fill_in('dataset_mbox', with: dataset_attributes[:mbox])
    fill_in('dataset_spatial', with: dataset_attributes[:spatial])
    fill_in('dataset_spatial', with: dataset_attributes[:spatial])
    fill_in('dataset_data_dictionary', with: dataset_attributes[:data_dictionary])
    fill_in('dataset_quality', with: dataset_attributes[:quality])
    fill_in('dataset_keyword', with: dataset_attributes[:keyword])
    fill_in('dataset_comments', with: dataset_attributes[:comments])
  end
end
