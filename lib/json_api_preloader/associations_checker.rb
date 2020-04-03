# frozen_string_literal: true

module JsonApiPreloader
  class AssociationsChecker
    def initialize(parent, association)
      @parent = parent
      @association = association
    end

    def call
      return unless parent_klass_associations.present?

      child_klass_associations&.fetch(association)
    end

    def self.associations
      @associations ||= AssociationsBuilder.new.call
    end

    private

    attr_reader :parent, :association

    def parent_klass_associations
      @parent_klass_associations ||=
        self.class.associations.detect { |el| el[:name] == parent }
    end

    def child_klass_associations
      @child_klass_associations ||=
        parent_klass_associations[:associations]
        .detect { |el| el.key?(association) }
    end
  end
end
