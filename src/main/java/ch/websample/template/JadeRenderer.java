package ch.websample.template;

import java.io.IOException;
import java.util.Map;

import de.neuland.jade4j.JadeConfiguration;
import de.neuland.jade4j.exceptions.JadeException;
import de.neuland.jade4j.template.ClasspathTemplateLoader;
import de.neuland.jade4j.template.JadeTemplate;

public class JadeRenderer {
	 
	// https://github.com/neuland/jade4j
	private static JadeConfiguration config;
	private String templateName;
	
	private JadeRenderer(String templateName) {
		this.templateName = templateName;
	}

	public static JadeRenderer template(String templateName) {
		return new JadeRenderer(templateName);
	}
	
	public String render(Map<String, Object> model) {
		initJadeConfig();
		return config.renderTemplate(getTemplate(), model);
	}

	private JadeTemplate getTemplate() {
		JadeTemplate template = null;
		try {
			template = config.getTemplate(templateName);
		} catch (JadeException | IOException e) {
			e.printStackTrace();
		}
		return template;
	}

	private void initJadeConfig() {
		if(config == null) {
			config = new JadeConfiguration();
			config.setPrettyPrint(true);	
			config.setTemplateLoader(new ClasspathTemplateLoader());
		}
	}
}
