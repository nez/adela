module Publishable
  extend ActiveSupport::Concern

  included do
    after_commit :run_transitions, on: [:create, :update]

    state_machine initial: :broke do
      state :broke
      state :documented
      state :refining
      state :refined
      state :published

      event :document do
        transition [:broke] => :documented, if: lambda { |resource| resource.valid?(:ckan) }
      end

      event :break_resource do
        transition [:documented] => :broke, unless: lambda { |resource| resource.valid?(:ckan) }
      end

      event :break_published_resource do
        transition [:published, :refined] => :refining, unless: lambda { |resource| resource.valid?(:ckan) }
      end

      event :refine_published_resource do
        transition [:refining, :published] => :refined, if: lambda { |resource| resource.valid?(:ckan) }
      end
    end
  end

  private

  def run_transitions
    document if can_document?
    break_resource if can_break_resource?
    refine_published_resource if can_refine_published_resource?
    break_published_resource if can_break_published_resource?
  end
end
