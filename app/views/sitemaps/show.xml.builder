xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc root_url
    xml.changefreq 'weekly'
    xml.priority 0.6
  end

  xml.url do
    xml.loc new_user_url(:protocol => 'https')
    xml.changefreq 'monthly'
    xml.priority 0.5
  end

  xml.url do
    xml.loc new_session_url(:protocol => 'https')
    xml.changefreq 'monthly'
    xml.priority 0.4
  end

  xml.url do
    xml.loc privacy_policy_url
    xml.changefreq 'monthly'
    xml.priority 0.3
  end
end
