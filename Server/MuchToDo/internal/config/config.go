package config

import (
	"strings"
	"github.com/spf13/viper"
)

// Config stores all configuration of the application.
type Config struct {
	ServerPort       string `mapstructure:"PORT"`
	MongoURI         string `mapstructure:"MONGO_URI"`
	DBName           string `mapstructure:"DB_NAME"`
	JWTSecretKey     string `mapstructure:"JWT_SECRET_KEY"`
	JWTExpirationHours int    `mapstructure:"JWT_EXPIRATION_HOURS"`
	EnableCache      bool   `mapstructure:"ENABLE_CACHE"`
	RedisAddr        string `mapstructure:"REDIS_ADDR"`
	RedisPassword    string `mapstructure:"REDIS_PASSWORD"`
	LogLevel      string `mapstructure:"LOG_LEVEL"`
	LogFormat     string `mapstructure:"LOG_FORMAT"`
}



func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName(".env")
	viper.SetConfigType("env")

	// IMPORTANT: Bind each environment variable explicitly
	viper.BindEnv("PORT")
	viper.BindEnv("MONGO_URI")
	viper.BindEnv("DB_NAME")
	viper.BindEnv("JWT_SECRET_KEY")
	viper.BindEnv("JWT_EXPIRATION_HOURS")
	viper.BindEnv("ENABLE_CACHE")
	viper.BindEnv("REDIS_ADDR")
	viper.BindEnv("REDIS_PASSWORD")
	viper.BindEnv("LOG_LEVEL")
	viper.BindEnv("LOG_FORMAT")

	viper.AutomaticEnv()

	// Set default values
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("ENABLE_CACHE", false)
	viper.SetDefault("JWT_EXPIRATION_HOURS", 72)

	// Try to read config file, but don't fail if it doesn't exist (in K8s we use env vars)
	err = viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			// Only return error if it's NOT a "file not found" error
			return
		}
		// File not found is OK - we'll use environment variables
		err = nil
	}

	err = viper.Unmarshal(&config)
	
	// Trim quotes from MONGO_URI if present (Viper bug with .env files)
	config.MongoURI = strings.Trim(config.MongoURI, "\"")
	
	return
}
// LoadConfig reads configuration from file or environment variables.
// func LoadConfig(path string) (config Config, err error) {
// 	viper.AddConfigPath(path)
// 	viper.SetConfigName(".env")
// 	viper.SetConfigType("env")

// 	viper.AutomaticEnv()

// 	// Set default values
// 	viper.SetDefault("PORT", "8080")
// 	viper.SetDefault("ENABLE_CACHE", false)
// 	viper.SetDefault("JWT_EXPIRATION_HOURS", 72)

// 	err = viper.ReadInConfig()
// 	if err != nil {
// 		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
// 			return
// 		}
// 	}

// 	err = viper.Unmarshal(&config)
// 	return
// }