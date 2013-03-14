RingsailDemos::Application.routes.draw do

  # Flickr photos demo
  match 'flickr/:id' => 'flickr#show'

  # Youtube videos demo
  match 'youtube/:id' => 'youtube#show'

end
