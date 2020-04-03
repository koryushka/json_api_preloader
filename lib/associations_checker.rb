# frozen_string_literal: true

class AssociationsChecker
  def initialize(parent, association)
    @parent = parent
    @association = association
  end

  def call
    return unless parent_klass_associations.present?

    child_klass_associations&.fetch(association)
  end

  private

  attr_reader :parent, :association, :element

  def associations
    @associations ||= models.map do |model_name|
      {
        associations: model_name.constantize.reflect_on_all_associations.map { |ac| { ac.name => ac.klass.name } },
        name: model_name
      }
    end
  end

  def models
    ApplicationRecord.descendants.collect(&:name)
  end

  def parent_klass_associations
    @parent_klass_associations ||=
      associations.detect { |el| el[:name] == parent }
  end

  def child_klass_associations
    @child_klass_associations ||=
      parent_klass_associations[:associations]
      .detect { |el| el.key?(association) }
  end
end
