# Registry API demonstrations

Quick demos of the Social Media Registry.

## Why Rails?

These demos (loosely) use Ruby on Rails. The demos may or may not have an actual website component, but Rails offers a bunch of design defaults that make building demos like these go quickly.

## Installation

    cp config/too_many_secrets.example.rb config/too_many_secrets.rb

Edit the too_many_secrets.rb file to specify your API keys and such.

## Running a demo

    rake -T |grep demo

List the demo tasks available. For example:

    rake demo:update_lists


