VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :typhoeus
end