// CONTAINS:
// the newpaper guts

// the overall container and html generator
/datum/news/paper
	var/title_template = "<div style='float:left'><h2>@T@</h2></div><h4>@C@</h4>"	// template of title at top of 1st page
	var/header_template = "<div style=\"float:left\">@T@</div><div style=\"float:right\">Page @C@</div><hr>"	// header at the top of each page from 2 onwards
	var/footer_template = "<div style='clear:both'><i>@@</i></div>"					// template of footer at end of each page
	var/article_template = "<div style='padding:1em'><h4>@T@</h4><p>@C@</p></div>"									// template of article title/content
	var/columns_per_page = 2														// number of columns

	var/title = "NT News"
	var/subtitle = "\"All the news that we feel fit to print.\""
	var/footer = "Copyright &copy; 2055 Nanotransen Corp."
	var/list/articles
	var/list/icons									// the photo icons

	var/list/pages									// this is generated by update()

/datum/news/paper/New()
	articles = new()
	icons = new()

// updates pages
/datum/news/paper/proc/update()
	// for each page, we allow 1 row of articles,
	// each page either being a full page or [columns_per_page] columns of articles
	pages = new()
	var/list/page_articles = new()
	for(var/datum/news/article/A in articles)
		if(A.full)
			if(page_articles.len > 0)					// finish partial row
				pages += generate_page(pages.len + 1, page_articles)
				page_articles = new()
			pages += generate_page(pages.len + 1, list(A))
		else
			page_articles += A							// fill a column
			if(page_articles.len >= columns_per_page)	// finish full row
				pages += generate_page(pages.len + 1, page_articles)
				page_articles = new()

	// finish final row
	if(page_articles.len > 0)
		pages += generate_page(pages.len + 1, page_articles)

// actaully make the page html
/datum/news/paper/proc/generate_page(page_num, list/articles)
	var/T = "<div style='background:#e8e8e8;border:1px outset #e0e0e0;padding:2em'>"

	// header
	if(page_num == 1)
		T += fill_template_2(title_template, title, subtitle)
	else
		T += fill_template_2(header_template, title, num2text(page_num))

	// articles
	for(var/datum/news/article/A in articles)
		if(A.full)
			T += "<div>" + fill_template_2(article_template, A.title, A.content) + "</div>"
		else
			T += "<div style='float:left' width='[num2text(100/articles.len)]%'>" \
				+ fill_template_2(article_template, A.title, A.content) + "</div>"

	// footer
	T += fill_template(footer_template, footer)
	T += "</div>"

	return T

/datum/news/paper/proc/fill_template(template, txt)
	var/cpos = findtext(template, "@@")

	if(cpos == 0)
		return template
	else
		return copytext(template, 1, cpos) \
			+ txt \
			+ copytext(template, cpos + 2)

/datum/news/paper/proc/fill_template_2(template, ttxt, ctxt)
	var/output = ""

	// title first
	var/tpos = findtext(template, "@T@")
	if(tpos == 0)
		output = template
	else
		output = copytext(template, 1, tpos) \
			+ ttxt \
			+ copytext(template, tpos + 3)

	// then content
	var/cpos = findtext(output, "@C@")
	if(cpos == 0)
		// do nothing
	else
		output = copytext(output, 1, cpos) \
			+ ctxt \
			+ copytext(output, cpos + 3)

	return output

// an article for the newspaper
/datum/news/article
	var/full = 0				// 1 for full width, 0 for single column
	var/title = "Untitled"		// title of article
	var/content = ""			// content of article
