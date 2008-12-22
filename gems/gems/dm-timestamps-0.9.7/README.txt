= dm-timestamps

DataMapper plugin which adds "magic" to created_at, created_on, et cetera.

= Using

This plugin works by looking for the "created_at," "updated_at," "created_on"
and "updated_on" properties. If they exist, it does the right thing by setting
them or updating them. The *at properties should be of type DateTime, while the
*on properties should be of type Date.

Alternatively, you can have all of this setup for you if you use the "timestamps"
helper:

  timestamps :at    # Add created_at and updated_at
  timestamps :on    # Add created_on and updated_on
  timestamps :created_at, :updated_on    # Add these only
