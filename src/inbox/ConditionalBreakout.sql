declare
    @beat int = 0,
    @maxBeats int = 3

set @beat = @beat + 1
if @beat > @maxBeats begin select 'Too many!' Message return end
select 'one' Beats

set @beat = @beat + 1
if @beat > @maxBeats begin select 'Too many!' Message return end
select 'two' Beats

set @beat = @beat + 1
if @beat > @maxBeats begin select 'Too many!' Message return end
select 'three' Beats

set @beat = @beat + 1
if @beat > @maxBeats begin select 'Too many!' Message return end
select 'four' Beats