using Azure.Identity;
using EventAttendeesApp.Data;
using Microsoft.EntityFrameworkCore;

namespace EventAttendeesApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // AppConfiguration の設定を追加
            builder.Host.ConfigureAppConfiguration((context, configBuilder) =>
            {
                configBuilder
                    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                    .AddJsonFile($"appsettings.{context.HostingEnvironment.EnvironmentName}.json", optional: true, reloadOnChange: true)
//                    .AddJsonFile("host.json", optional: true, reloadOnChange: true)
                    .AddEnvironmentVariables()
                    .AddCommandLine(args);

                if (context.HostingEnvironment.IsDevelopment())
                {
                    configBuilder.AddUserSecrets<Program>(); // ユーザーシークレットの読み込み
                }

                if (!context.HostingEnvironment.IsDevelopment())
                {
                    // KeyVault を作成し MSI を有効化、Azure Functions のアプリケーションIDをアクセスポリシーに追加
                    configBuilder.AddAzureKeyVault(new Uri(Environment.GetEnvironmentVariable("KEY_VAULT_URL")), new DefaultAzureCredential());
                }
            });

            // サービスの追加
            builder.Services.AddRazorPages();

            // データベースコンテキストの追加
            var sqlConnectionString = builder.Configuration.GetSection("EventAttendeesApp").GetSection("SqlDbConnection").Value;

            if (string.IsNullOrEmpty(sqlConnectionString))
            {
                throw new InvalidOperationException("The SQL database connection string is not configured.");
            }

            builder.Services.AddDbContext<EventAttendeesContext>(options =>
                options.UseSqlServer(sqlConnectionString));


            var app = builder.Build();

            // HTTP request pipeline の設定
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            // 最初に表示するページを /EventAttendees にリダイレクト
            app.MapGet("/", context =>
            {
                context.Response.Redirect("/EventAttendees");
                return Task.CompletedTask;
            });

            app.MapRazorPages();

            app.Run();
        }
    }
}
