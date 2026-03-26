package com.civicfix;

import com.civicfix.dao.DBConnection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;


@WebListener
public class AppStartup implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("🚀 CivicFix starting up...");
        DBConnection.initializeDatabase();
        System.out.println("✅ CivicFix ready at http://localhost:8080/");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("🛑 CivicFix shutting down.");
    }
}