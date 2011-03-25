package org.molgenis.framework.ui.html;

/**
 * Show text within a paragraph (html <p> tag).
 */
public class TextParagraph extends HtmlInput
{
	public TextParagraph(String name)
	{
		this(name, null);
	}

	public TextParagraph(String name, Object value)
	{
		super(name, value);
	}

	@Override
	public String toHtml()
	{
		// Don't escape special characters, so user can insert html into the paragraph
		return "<p id=\"" + getId() + "\" name=\"" + getName() + "\""
				+ tabIndex + " >" + getValue(false) + "</p>";
	}
}
