using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace againapi.Migrations
{
    /// <inheritdoc />
    public partial class UpdateUserReviewModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AppointmentId",
                table: "UserReviews");

            migrationBuilder.AddColumn<string>(
                name: "UserEmail",
                table: "UserReviews",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "UserEmail",
                table: "UserReviews");

            migrationBuilder.AddColumn<int>(
                name: "AppointmentId",
                table: "UserReviews",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }
    }
}
