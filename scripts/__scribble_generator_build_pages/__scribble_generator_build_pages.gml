function __scribble_generator_build_pages()
{
    var _word_grid    = global.__scribble_word_grid;
    var _line_grid    = global.__scribble_line_grid;
    var _control_grid = global.__scribble_control_grid; //This grid is cleared at the bottom of __scribble_generate_model()
    
    with(global.__scribble_generator_state)
    {
        var _element          = element;
        var _model_max_height = model_max_height;
        var _line_count       = line_count;
        var _control_count    = control_count;
        var _wrap_no_pages    = _element.wrap_no_pages;
    }
    
    var _simulated_model_height = _model_max_height / fit_scale;
    
    var _model_height = 0;
    
    // Set up a new page and set its starting glyph
    // We'll set the ending glyph in the loop below
    var _page_data = __new_page();
    _page_data.__glyph_start = _word_grid[# _line_grid[# 0, __SCRIBBLE_PARSER_LINE.WORD_START], __SCRIBBLE_PARSER_WORD.GLYPH_START];
    
    if (_line_count <= 0)
    {
        _page_data.__glyph_end = _page_data.__glyph_start;
    }
    else
    {
        var _line_y = 0;
        var _i = 0;
        repeat(_line_count)
        {
            var _line_height = _line_grid[# _i, __SCRIBBLE_PARSER_LINE.HEIGHT];
            if (_wrap_no_pages || (_line_y + _line_height < _simulated_model_height))
            {
                _line_grid[# _i, __SCRIBBLE_PARSER_LINE.Y] = _line_y;
                _line_y += _line_height;
            }
            else
            {
                // Set the ending glyph - we set the starting glyph when the new page is created (above for the 0th page, and below for subsequent pages)
                _page_data.__glyph_end = _word_grid[# _line_grid[# _i-1, __SCRIBBLE_PARSER_LINE.WORD_END], __SCRIBBLE_PARSER_WORD.GLYPH_END];
                
                ////TODO - Probably need to move the page glyph start/end code after bidi correction
                ////TODO - Implement handling for R2L (word count not glyph count)
                //
                //// Set up the character indexes for the page, relative to the character index of the first glyph on the page
                //var _page_char_start = _glyph_grid[# _page_data.__glyph_start, __SCRIBBLE_PARSER_GLYPH.CHARACTER_INDEX];
                //ds_grid_add_region(_glyph_grid, _page_data.__glyph_start, __SCRIBBLE_PARSER_GLYPH.CHARACTER_INDEX, _page_data.__glyph_end, __SCRIBBLE_PARSER_GLYPH.CHARACTER_INDEX, -_page_char_start);
                //
                //// Set the character count for the page too
                //_page_data.__character_count = 1 + _glyph_grid[# _page_data.__glyph_end, __SCRIBBLE_PARSER_GLYPH.CHARACTER_INDEX];
                
                _line_grid[# _i, __SCRIBBLE_PARSER_LINE.Y] = _line_y;
                _line_y = _line_height;
                
                if (is_infinity(_line_height))
                {
                    __scribble_error("Manual page breaks not implemented yet");
                }
                else
                {
                    // Create a new page
                    _page_data = __new_page();
                    _page_data.__glyph_start = _word_grid[# _line_grid[# _i, __SCRIBBLE_PARSER_LINE.WORD_START], __SCRIBBLE_PARSER_WORD.GLYPH_START];
                    
                    //We also need to increment the page counter for our controls
                    ds_grid_add_region(_control_grid, _line_grid[# _i-1, __SCRIBBLE_PARSER_LINE.CONTROL_END], __SCRIBBLE_PARSER_CONTROL.PAGE, _control_count - 1, __SCRIBBLE_PARSER_CONTROL.PAGE, 1);
                }
            }
            
            _model_height = max(_model_height, _line_y);
        }
        
        // Set the ending glyph - we set the starting glyph when the new page is created (above for the 0th page, and below for subsequent pages)
        _page_data.__glyph_end = _word_grid[# _line_grid[# _i, __SCRIBBLE_PARSER_LINE.WORD_END], __SCRIBBLE_PARSER_WORD.GLYPH_END];
    }
    
    height = _model_height;
}