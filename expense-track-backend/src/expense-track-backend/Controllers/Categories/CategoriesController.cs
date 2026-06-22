using System.Security.Claims;
using Categories.Application.Features.CreateCategory;
using Categories.Application.Features.GetCategories;
using expense_track_backend.Requests;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using expense_track_backend.Extensions;

namespace expense_track_backend.Controllers.Categories;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CategoriesController : ControllerBase
{
    private readonly IMediator _mediator;
    
    public  CategoriesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetCategories()
    {
        try
        {
            var userId = User.GetUserId();

            var query = new GetCategoriesQuery(userId);
            var categories = await _mediator.Send(query);

            return Ok(categories);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryRequest request)
    {
        try
        {
            var userId = User.GetUserId();

            var command = new CreateCategoryCommand(
                userId,
                request.Name,
                request.Icon,
                request.Color
            );
            
            var categoryId = await _mediator.Send(command);

            return Created(string.Empty, new
            {
                Id = categoryId,
                Message = "Categoria creada correctamente"
            });
        } catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}