const ICONS = {
    utility: [
        'activity', 'ad_set', 'add', 'adduser', 'adjust_value', 'advanced_function', 'advertising', 'agent_home', 'agent_session', 'aggregation_policy', 'alert', 'all', 'anchor', 'animal_and_nature', 'announcement', 'answer', 'answered_twice', 'anywhere_alert', 'anywhere_chat', 'apex_plugin', 'apex', 'approval', 'apps', 'archive', 'arrow_bottom', 'arrow_left', 'arrow_right', 'arrow_top', 'arrowdown', 'arrowup', 'asset_audit', 'asset_object', 'asset_warranty', 'assignment', 'attach', 'automate', 'away', 'back', 'ban', 'block_visitor', 'bold', 'bookmark_alt', 'bookmark', 'bottom_align', 'breadcrumbs', 'broadcast', 'brush', 'bucket', 'budget_category_value', 'budget_period', 'bug', 'builder', 'bundle_config', 'bundle_policy', 'button_choice', 'calculated_insights', 'call', 'campaign', 'cancel_file_request', 'cancel_transfer', 'capacity_plan', 'capslock', 'captions', 'cart', 'case', 'cases', 'center_align_text', 'center_align', 'change_owner', 'change_record_type', 'change_request', 'chart', 'chat', 'check', 'checkin', 'checkout', 'chevrondown', 'chevronleft', 'chevronright', 'chevronup', 'choice', 'classic_interface', 'clear', 'clock', 'close', 'collapse_all', 'collection_alt', 'collection_variable', 'collection', 'color_swatch', 'comments', 'company', 'component_customization', 'connected_apps', 'constant', 'contact_request', 'contact', 'contract_alt', 'contract_doc', 'contract_line_outcome_data', 'contract_line_outcome', 'contract_payment', 'contract', 'copy_to_clipboard', 'copy', 'coupon_codes', 'crossfilter', 'currency_input', 'currency', 'custom_apps', 'customer_workspace', 'customer', 'cut', 'dash', 'data_mapping', 'data_model', 'database', 'datadotcom', 'date_input', 'date_time', 'dayview', 'delete', 'deprecate', 'description', 'desktop_and_phone', 'desktop_console', 'desktop', 'detach', 'dialing', 'diamond', 'discounts', 'dislike', 'display_rich_text', 'display_text', 'dock_panel', 'down', 'download', 'drag_and_drop', 'drag', 'duration_downscale', 'dynamic_record_choice', 'edit_form', 'edit', 'education', 'einstein', 'email_open', 'email', 'emoji', 'end_call', 'end_chat', 'end_messaging_session', 'engage', 'enter', 'entitlement', 'erect_window', 'error', 'event_ext', 'event', 'events', 'expand_all', 'expand_alt', 'expand', 'fallback', 'favorite', 'feed', 'field_sales', 'file', 'filter_criteria_rule', 'filter_criteria', 'filter', 'filterList', 'flow_alt', 'flow', 'food_and_drink', 'form', 'formula', 'forward_up', 'forward', 'freeze_column', 'frozen', 'fulfillment_order', 'full_width_view', 'funding_award_adjustment', 'funding_requirement', 'global_constant', 'graph', 'groups', 'hazmat_equipment', 'help_center', 'help_doc_ext', 'help', 'hide_mobile', 'hide', 'hierarchy', 'high_velocity_sales', 'holiday_operating_hours', 'home', 'http', 'identity', 'image', 'in_app_assistant', 'inbox', 'incident', 'incoming_call', 'info_alt', 'info', 'insert_tag_field', 'insert_template', 'inspector_panel', 'internal_share', 'italic', 'jump_to_bottom', 'jump_to_left', 'jump_to_right', 'jump_to_top', 'justify_text', 'kanban', 'key_dates', 'key', 'keyboard_dismiss', 'keypad', 'knowledge_base', 'knowledge_smart_link', 'label', 'labels', 'layers', 'layout_banner', 'layout_card', 'layout_overlap', 'layout_tile', 'layout', 'lead', 'leave_conference', 'left_align_text', 'left_align', 'left', 'level_down', 'level_up', 'light_bulb', 'lightning_extension', 'lightning_inspector', 'like', 'link', 'linked', 'list', 'listen', 'live_message', 'location_permit', 'location', 'lock', 'locker_service_api_viewer', 'locker_service_console', 'log_a_call', 'logout', 'loop', 'lower_flag', 'macros', 'magicwand', 'maintenance_plan', 'mark_all_as_read', 'matrix', 'meet_content_source', 'meet_focus_content', 'meet_focus_equal', 'meet_focus_presenter', 'meet_present_panel', 'merge_field', 'merge', 'metrics', 'middle_align', 'minimize_window', 'missed_call', 'money', 'moneybag', 'monthlyview', 'move', 'multi_picklist', 'multi_select_checkbox', 'muted', 'new_direct_message', 'new_window', 'new', 'news', 'no_return', 'note', 'notebook', 'notification', 'number_input', 'office365', 'offline_briefcase', 'offline_cached', 'offline', 'omni_channel', 'open_folder', 'open', 'opened_folder', 'opportunity', 'orchestrator', 'orders', 'org_chart', 'outbound_call', 'outcome', 'overflow', 'package_org_beta', 'package_org', 'package', 'page', 'palette', 'password', 'paste', 'pause_alt', 'pause', 'payment_gateway', 'pdf_ext', 'people', 'percent', 'phone_landscape', 'phone_portrait', 'photo', 'picklist_choice', 'picklist_type', 'picklist', 'pin', 'pinned', 'planning_poker', 'play', 'podcast_webinar', 'pop_in', 'power', 'preview', 'price_book_entries', 'price_books', 'pricing_workspace', 'print', 'priority', 'privately_shared', 'problem', 'process', 'product_consumed_state', 'product_quantity_rules', 'product_service_campaign_item', 'product_service_campaign', 'product_transfer_state', 'product_transfer', 'product_warranty_term', 'product_workspace', 'product', 'products', 'profile', 'promotion_segments', 'promotions_workspace', 'promotions', 'prompt_edit', 'prompt', 'propagation_policy', 'proposition', 'push', 'puzzle', 'qualifications', 'question_mark', 'question', 'questions_and_answers', 'queue', 'quick_text', 'quip', 'quotation_marks', 'quote', 'radio_button', 'rating', 'reassign', 'recipe', 'record_alt', 'record_create', 'record_delete', 'record_lookup', 'record_update', 'record', 'recurring_exception', 'recycle_bin_empty', 'recycle_bin_full', 'redo', 'refresh', 'relate', 'reminder', 'remove_formatting', 'remove_link', 'replace', 'reply_all', 'reply', 'report_issue', 'reset_password', 'resource_absence', 'resource_capacity', 'resource_territory', 'restriction_policy', 'retail_execution', 'retweet', 'ribbon', 'richtextbulletedlist', 'richtextindent', 'richtextnumberedlist', 'richtextoutdent', 'right_align_text', 'right_align', 'right', 'rotate', 'routing_offline', 'rows', 'rules', 'salesforce_page', 'salesforce1', 'save', 'scan', 'screen', 'search', 'section', 'segments', 'send_log', 'send', 'sentiment_negative', 'sentiment_neutral', 'serialized_product_transaction', 'serialized_product', 'service_contract', 'service_territory_policy', 'settings', 'setup_assistant_guide', 'setup_modal', 'setup', 'share_file', 'share_mobile', 'share_post', 'share', 'shield', 'shift_pattern_entry', 'shift_pattern', 'shift_scheduling_operation', 'shift_ui', 'shopping_bag', 'shortcuts', 'side_list', 'signature', 'signpost', 'skip_back', 'skip_forward', 'skip', 'slack_conversations', 'slack', 'slider', 'smiley_and_people', 'sms', 'snippet', 'sobject_collection', 'sobject', 'socialshare', 'sort_policy', 'sort', 'spacer', 'spinner', 'stage_collection', 'stage', 'standard_objects', 'steps', 'stop', 'store', 'strategy', 'strikethrough', 'success', 'summary', 'summarydetail', 'survey', 'swarm_request', 'swarm_session', 'switch', 'symbols', 'sync', 'system_and_global_variable', 'table_settings', 'table', 'tableau', 'tablet_landscape', 'tablet_portrait', 'tabset', 'talent_development', 'target_mode', 'target', 'task', 'tax_policy', 'tax_rate', 'tax_treatment', 'text_background_color', 'text_color', 'text_template', 'text', 'textarea', 'textbox', 'threedots_vertical', 'threedots', 'thunder', 'tile_card_list', 'toggle_panel_bottom', 'toggle_panel_left', 'toggle_panel_right', 'toggle_panel_top', 'toggle', 'tollways', 'top_align', 'topic', 'topic2', 'touch_action', 'tour_check', 'tour', 'tracker', 'trail', 'trailblazer_ext', 'trailhead_alt', 'trailhead_ext', 'trailhead', 'transparent', 'transport_bicycle', 'transport_heavy_truck', 'transport_light_truck', 'transport_walking', 'travel_and_places', 'trending', 'truck', 'turn_off_notifications', 'type_tool', 'type', 'undelete', 'undeprecate', 'underline', 'undo', 'unlinked', 'unlock', 'unmuted', 'up', 'upload', 'user_role', 'user', 'variable', 'variation_attribute_setup', 'variation_products', 'video_off', 'video', 'voicemail_drop', 'volume_high', 'volume_low', 'volume_off', 'waits', 'warning', 'warranty_term', 'watchlist', 'water', 'weeklyview', 'wellness', 'wifi', 'work_forecast', 'work_order_type', 'workforce_engagement', 'world', 'your_account', 'yubi_key', 'zoomin', 'zoomout'
    ],
};

export { ICONS };