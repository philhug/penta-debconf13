class View_submission_event < Momomoto::Table
  default_order( Momomoto::lower(:title,:subtitle))
end

