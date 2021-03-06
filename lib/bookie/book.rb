module Bookie
  class Book
    def initialize(name)
      @name     = name
      @chapters = [] 
    end

    attr_reader :name, :chapters
      
    def chapter(name, file)
      chapters << [name, file]
    end

    # FIXME: This is inefficient, it should be possible to fire up the parser
    # just once with many emitters.
    def render(basename, emitters)
      emitters = *emitters

      emitters.each do |emitter|
        emitter = emitter.new if emitter.is_a? Class

        chapters.each_with_index do |(name, file), i|
          emitter.start_new_chapter(header: "Chapter #{i+1}",
                                    title:  name)
          Bookie::Parser.parse(File.read(file), emitter)
        end

        output_file = "#{basename}#{emitter.class.extension}"
        emitter.render(file: output_file)
      end
    end
  end
end
