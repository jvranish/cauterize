require 'time'

module Cauterize
  class CSBuilder
    attr_reader :cs

    def initialize(cs_file, name="cauterize")
      @cs = cs_file
      @name = name.camel
    end

    def build
      build_cs
    end

    private

    def build_cs
      f = four_space_formatter

      f << "/* WARNING: This is generated code. Do not edit this file directly. */"
      f << ""
      f << "using System;"
      f << "using Cauterize;"
      f.blank_line
      f << "namespace #{@name}"
      f.braces do
        f << "public static class #{@name}Cauterize"
        f.braces do
          f << "public static CauterizeInfo Info = new CauterizeInfo"
          f.braces do
            f << "Name = \"#{@name}\","
            f << "GeneratedVersion = \"#{Cauterize.get_version}\","
            f << "GeneratedDate = \"#{DateTime.now.to_s}\","
            f << "ModelHashLength = #{BaseType.digest_class.new.length},"
            f << "ModelHash = new byte[] {#{BaseType.model_hash.bytes.to_a.join(", ")}}"
          end
          f << ";"
        end
        f.blank_line

        instances = BaseType.all_instances
        builders = instances.map {|i| Builders.get(:cs, i)}

        builders.each { |b| b.enum_defn(f) }
        builders.each { |b| b.class_defn(f) }
        # # should we really do these, or is it annotations and a custom
        # # formatter in support???
        # builders.each { |b| b.packer_defn(f) }
        # builders.each { |b| b.unpacker_defn(f) }
      end

      File.open(@cs, "wb") do |fh|
        fh.write(f.to_s)
      end
    end
  end
end
