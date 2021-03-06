class DefineFullTextSearchIndex < ActiveGroonga::Migration
  def up
    create_table("bigram",
                 :type => :patricia_trie,
                 :key_type => "ShortText",
                 :default_tokenizer => "TokenBigram",
                 :key_normalize => true) do |table|
      table.index("entries.title")
      table.index("entries.body")
      table.index("entries.basename")
      table.index("authors._key")
    end
  end

  def down
    remove_table("bigram")
  end
end
