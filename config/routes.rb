RingsailDemos::Application.routes.draw do

  # Flickr photos demo
  match 'flickr/:id' => 'flickr#show'

end
