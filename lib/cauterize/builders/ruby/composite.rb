module Cauterize::Builders::Ruby
  class Composite < Buildable
    def render
      @blueprint.name.to_s.camel
    end

    def class_defn(f)
      f << "  class #{render} < CauterizeComposite"
      @blueprint.fields.values.each do |field|
        f << "    def #{field.name}() fields[:#{field.name}] end"
      end
      f << "    def self.fields"
      f << "      {"
      @blueprint.fields.values.each do |field|
        t = Cauterize::Builders.get(:ruby, field.type).render
        f << "        #{field.name}: #{t},"
      end
      f << "      }"
      f << "    end"
      f << "  end"
      f << ""
    end
  end
end

Cauterize::Builders.register(:ruby, Cauterize::Composite, Cauterize::Builders::Ruby::Composite)
