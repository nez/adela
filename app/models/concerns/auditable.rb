module Auditable
  extend ActiveSupport::Concern

  included do
    audited
  end
end
