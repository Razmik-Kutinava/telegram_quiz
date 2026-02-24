require 'net/http'
require 'uri'
require 'fileutils'

# Создаем папки
images_dir = File.join(__dir__, '..', 'app', 'assets', 'images', 'cocktails')
FileUtils.mkdir_p(images_dir)

# Список изображений для скачивания
images = {
  'logo.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/85d5a5c71-5e4c-47b1-9a2e-c4b9f8e3d2a1.png',
  'cocktail68.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/155afb6f6-0ce7-4776-86fb-60386e59386d.png',
  'cocktail69.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/b2c3d4e5-2345-6789-abcd-ef0123456789.png',
  'cocktail70.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/a1b2c3d4-1234-5678-9abc-def012345678.png',
  'cocktail71.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/c3d4e5f6-3456-789a-bcde-f01234567890.png',
  'shot1.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/d4e5f6g7-4567-89ab-cdef-012345678901.png',
  'shot2.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/e5f6g7h8-5678-9abc-def0-123456789012.png',
  'shot3.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/f6g7h8i9-6789-abcd-ef01-234567890123.png',
  'shot4.png' => 'https://image.qwenlm.ai/public_source/e0ec28be-77bc-4d49-8d73-60c4e43e43d0/g7h8i9j0-789a-bcde-f012-345678901234.png'
}

images.each do |filename, url|
  puts "Downloading #{filename}..."
  
  begin
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    
    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)
    
    if response.code == '200'
      file_path = File.join(images_dir, filename)
      File.binwrite(file_path, response.body)
      puts "✓ Saved: #{file_path}"
    else
      puts "✗ Failed: HTTP #{response.code} for #{filename}"
    end
  rescue => e
    puts "✗ Error downloading #{filename}: #{e.message}"
  end
end

puts "\nDone! Images saved to app/assets/images/cocktails/"
