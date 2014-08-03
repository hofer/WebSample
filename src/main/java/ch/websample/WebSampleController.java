package ch.websample;

import static ch.websample.template.JadeTemplate.*;
import static spark.Spark.get;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import spark.Request;
import spark.Response;
import spark.Route;
import spark.servlet.SparkApplication;

public class WebSampleController implements SparkApplication {
	
	public static final String ROUTE_HELLO = "/hello";
	
	@Override
	public void init() {
		get(new Route("/") {
			@Override
			public Object handle(Request request, Response response) {
				response.redirect(ROUTE_HELLO);
				return null;
			}
		});

		get(new Route(ROUTE_HELLO) {
			@Override
			public Object handle(Request request, Response response) {

	        	 List<Book> books = new ArrayList<Book>();
	        	 books.add(new Book("The Hitchhiker's Guide to the Galaxy", 5.70, true));
	        	 books.add(new Book("Life, the Universe and Everything", 5.60, false));
	        	 books.add(new Book("The Restaurant at the End of the Universe", 5.40, true));

	        	 Map<String, Object> model = new HashMap<String, Object>();
	        	 model.put("books", books);
	        	 model.put("pageName", "My Bookshelf");
				
	            return indexPage.render(model); 
			}
		});

		get(new Route("/hello/:name") {
			@Override
			public Object handle(Request request, Response response) {
				return  String.format("Hello, %s!", request.params(":name"));
			}
		});
	}
}