package org.islandora.tomcat.valves;

import org.apache.catalina.connector.Request;
import org.apache.catalina.connector.Response;
import org.apache.catalina.valves.ValveBase;

import javax.servlet.ServletException;
import java.io.IOException;

import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;

public class HealthCheckValve extends ValveBase {
    private static final Set<String> HEALTH_CHECK_URIS = new HashSet<>(Arrays.asList(
        "/fits/version",
        "/fcrepo/rest/fcr:systeminfo",
        // blazegraph
        "/bigdata/status"
    ));

    @Override
    public void invoke(Request request, Response response) throws IOException, ServletException {
        String uri = request.getRequestURI();

        if (uri != null && HEALTH_CHECK_URIS.contains(uri)) {
            request.setAttribute("skipHealthcheck", Boolean.TRUE);
        }

        getNext().invoke(request, response);
    }
}
