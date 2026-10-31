package com.foodie.reward.config;

import javax.sql.DataSource;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

@Component
@Profile("!oracle")
public class DemoDataSeeder implements CommandLineRunner {

    private final DataSource dataSource;
    private final JdbcTemplate jdbc;

    public DemoDataSeeder(DataSource dataSource, JdbcTemplate jdbc) {
        this.dataSource = dataSource;
        this.jdbc = jdbc;
    }

    @Override
    public void run(String... args) {
        Integer customerCount = jdbc.queryForObject("SELECT COUNT(*) FROM customers", Integer.class);
        if (customerCount != null && customerCount == 0) {
            new ResourceDatabasePopulator(new ClassPathResource("data.sql")).execute(dataSource);
        }
    }
}
