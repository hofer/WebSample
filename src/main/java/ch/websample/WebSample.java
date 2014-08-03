package ch.websample;

import java.util.EnumSet;

import javax.servlet.DispatcherType;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.FilterHolder;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHandler;

public class WebSample {

  public static void main(final String[] args) throws Exception {
	  
    Server server = new Server(8083);
    ServletHandler handler = new ServletHandler();

    ServletContextHandler context0 = new ServletContextHandler();
    context0.setContextPath("/");
    context0.setHandler(handler);
    
    server.setHandler(context0);
    
    FilterHolder holder = handler.addFilterWithMapping(spark.servlet.SparkFilter.class, "/*", EnumSet.of(DispatcherType.REQUEST));
    holder.setInitParameter("applicationClass", WebSampleController.class.getName());

    server.start();
    server.join();
  }
}