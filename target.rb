def target(file)
  if File.exist?(file)
    puts "Target #{file} already exists, skipping."
  else
    puts "Building target #{file}."
    yield file
  end
end
