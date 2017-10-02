require 'spec_helper'

describe Dataset do
  describe '#valid?' do
    let(:dataset) { create(:dataset) }

    it 'should be valid with all the mandatory fields' do
      expect(dataset).to be_valid
    end

    it 'should not be valid without a distribution' do
      dataset.distributions = []
      expect(dataset).not_to be_valid
    end

    it 'should not be valid with a duplicated title' do
      new_dataset = build(:dataset, title: dataset.title)
      expect(new_dataset).not_to be_valid
    end

    it 'should not be valid with higher initial perido that end periodo' do
      dataset.temporal_init_date = '2016-11-25'
      dataset.temporal_term_date = '2015-11-01'

      expect(dataset).not_to be_valid
    end
  end

  describe '#valid(:inventory)' do
    let(:dataset) { create(:dataset) }

    it 'should be valid with all the mandatory fields' do
      expect(dataset).to be_valid(:inventory)
    end

    it 'should not be valid without a title' do
      dataset.title = nil
      expect(dataset).not_to be_valid(:inventory)
    end

    it 'should not be valid without a contact_position' do
      dataset.contact_position = nil
      expect(dataset).not_to be_valid(:inventory)
    end

    it 'should not be valid without a public_access flag' do
      dataset.public_access = nil
      expect(dataset).not_to be_valid(:inventory)
    end

    it 'should not be valid without a publish_date' do
      dataset.publish_date = nil
      expect(dataset).not_to be_valid(:inventory)
    end
  end

  describe '#valid(:catalog)' do
    let(:dataset) { create(:dataset) }

    it 'should be valid with all the mandatory fields' do
      expect(dataset).to be_valid(:catalog)
    end

    it 'should not be valid without a description' do
      dataset.description = nil
      expect(dataset).not_to be_valid(:catalog)
    end

    it 'should not be valid without an accrual_periodicity' do
      dataset.accrual_periodicity = nil
      expect(dataset).not_to be_valid(:catalog)
    end

    it 'should not be valid without a public_access flag' do
      dataset.public_access = nil
      expect(dataset).not_to be_valid(:catalog)
    end

    it 'should not be valid without a publish_date' do
      dataset.publish_date = nil
      expect(dataset).not_to be_valid(:catalog)
    end
  end

  describe '#valid(:ckan)' do
    let!(:dataset) { create(:dataset_with_sector) }

    it 'should be valid with all the mandatory fields' do
      expect(dataset).to be_valid(:ckan)
    end

    it 'should not be valid without a title' do
      dataset.title = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without a description' do
      dataset.description = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without an accrual_periodicity' do
      dataset.accrual_periodicity = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without an contact_position' do
      dataset.contact_position = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without a mbox' do
      dataset.mbox = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without the temporal field' do
      allow(dataset).to receive(:temporal) { nil }

      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without the sector field' do
      dataset.sector = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without the keyword field' do
      dataset.keyword = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without the data_dictionary field' do
      dataset.data_dictionary = nil
      expect(dataset).not_to be_valid(:ckan)
    end

    it 'should not be valid without a publish_date' do
      dataset.publish_date = nil
      expect(dataset).not_to be_valid(:ckan)
    end
  end

  describe '#state' do
    let!(:dataset) { create(:dataset_with_sector) }

    it 'should be broke by default' do
      dataset.keyword = nil # this makes valid?(:ckan) => false
      dataset.save
      expect(dataset.state).to eql('broke')
    end

    it 'should be documented if valid?(:ckan)' do
      expect(dataset.state).to eql('documented')
    end

    it 'should be refining if brokes after published' do
      dataset.update_attribute(:state, 'published')
      dataset.keyword = nil # this makes valid?(:ckan) => false
      dataset.save
      expect(dataset.state).to eql('refining')
    end

    it 'should be refined if valid?(:ckan) after refining ' do
      dataset.update_attribute(:state, 'refining')
      dataset.save
      expect(dataset.state).to eql('refined')
    end
  end

  context '#identifier' do
    let(:dataset) { create(:dataset, title: 'Módulos de internet gratuitos en Xalapa') }

    it 'should generate a slugged identifier from title' do
      expect(dataset.identifier).to eql('modulos-de-internet-gratuitos-en-xalapa')
    end
  end

  context '#openess_rating' do
    let(:dataset) { create(:dataset) }
    let(:distribution) { dataset.distributions.first }

    it 'should have an openess rating score of 1' do
      expect(dataset.openess_rating).to eq(1)
    end

    it 'should have an openess rating score of 2 with a xls distribution' do
      distribution.update_attribute(:format, 'xls')
      expect(dataset.openess_rating).to eq(2)
    end

    it 'should have an openess rating score of 2 with a xlsx distribution' do
      distribution.update_attribute(:format, 'xlsx')
      expect(dataset.openess_rating).to eq(2)
    end

    it 'should have an openess rating score of 2 with a csv distribution' do
      distribution.update_attribute(:format, 'csv')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a tsv distribution' do
      distribution.update_attribute(:format, 'tsv')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a psv distribution' do
      distribution.update_attribute(:format, 'psv')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a json distribution' do
      distribution.update_attribute(:format, 'json')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a kml distribution' do
      distribution.update_attribute(:format, 'kml')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a kmz distribution' do
      distribution.update_attribute(:format, 'kmz')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a xml distribution' do
      distribution.update_attribute(:format, 'xml')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 2 with a shp distribution' do
      distribution.update_attribute(:format, 'shp')
      expect(dataset.openess_rating).to eq(3)
    end

    it 'should have an openess rating score of 5 with a rdf distribution' do
      distribution.update_attribute(:format, 'rdf')
      expect(dataset.openess_rating).to eq(4)
    end

    it 'should have an openess rating score of 5 with a lod distribution' do
      distribution.update_attribute(:format, 'lod')
      expect(dataset.openess_rating).to eq(5)
    end
  end

  context '#publisher' do
    let(:dataset) { create(:dataset) }

    it 'should be equal to the organization title' do
      organization = dataset.catalog.organization.title
      expect(dataset.publisher).to eql(organization)
    end
  end

  context '#keywords' do
    let(:dataset) { create(:dataset) }

    it 'should include the dataset keyword' do
      expect(dataset.keywords).to include(dataset.keyword)
    end

    it 'should include the organization sectors' do
      organization = create(:organization_with_sector)
      dataset.catalog.organization = organization
      expect(dataset.keywords).to include(organization.sectors.first.slug)
    end

    it 'should include the organization gov_type' do
      organization = create(:autonomous_organization)
      dataset.catalog.organization = organization
      expect(dataset.keywords).to include(organization.gov_type)
    end
  end
end
