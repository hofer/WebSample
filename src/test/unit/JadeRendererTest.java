import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.Before;
import org.junit.Test;

import ch.websample.Book;
import ch.websample.template.JadeTemplate;

public class JadeRendererTest {

	@Before
	public void setUp() {

	}

	@Test
	public void shouldRenderIndexPage() throws Exception {

		List<Book> books = new ArrayList<Book>();
		books.add(new Book("The Hitchhiker's Guide to the Galaxy", 5.70, true));
		books.add(new Book("Life, the Universe and Everything", 5.60, false));
		books.add(new Book("The Restaurant at the End of the Universe", 5.40, true));

		Map<String, Object> model = new HashMap<String, Object>();
		model.put("books", books);
		model.put("pageName", "My Bookshelf");

		Document doc = Jsoup.parse(JadeTemplate.indexPage.render(model));
	}
}
