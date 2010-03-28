Given(/the next request will rate limit for (\d)+ seconds/) do |seconds|
  seconds = seconds.to_i
  Artifice.activate_with(FakeRateLimit.new(seconds))
end

When 'I hit the rate limit' do
  harvest_api.clients.all
end

Then 'a rate limiting error will be raised when I hit the rate limit with the standard client' do
  lambda { standard_api.clients.all }.should raise_error(Harvest::RateLimited)
end

When 'I hit the rate limit with a robust client' do
  @time = Time.now
  harvest_api.clients.all
end

Then 'the robust client should wait for the rate limit to reset' do
  Time.now.should be_close(@time + 5, 2)
end

Then 'I should be able to make a request again' do
  harvest_api.clients.all
  harvest_api.clients.all
end