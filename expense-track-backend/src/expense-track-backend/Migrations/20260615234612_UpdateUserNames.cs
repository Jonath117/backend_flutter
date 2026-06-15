using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace expense_track_backend.Migrations
{
    /// <inheritdoc />
    public partial class UpdateUserNames : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "username",
                schema: "identity",
                table: "users",
                newName: "name");

            migrationBuilder.AddColumn<string>(
                name: "last_name",
                schema: "identity",
                table: "users",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "last_name",
                schema: "identity",
                table: "users");

            migrationBuilder.RenameColumn(
                name: "name",
                schema: "identity",
                table: "users",
                newName: "username");
        }
    }
}
